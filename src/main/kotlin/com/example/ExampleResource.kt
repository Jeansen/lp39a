package com.example

import com.fasterxml.jackson.databind.ObjectMapper
import io.kubernetes.client.admissionreview.models.AdmissionResponse
import io.kubernetes.client.admissionreview.models.AdmissionReview
import io.kubernetes.client.admissionreview.models.Status
import jakarta.ws.rs.Consumes
import jakarta.ws.rs.POST
import jakarta.ws.rs.Path
import jakarta.ws.rs.Produces
import jakarta.ws.rs.core.MediaType
import org.jboss.logging.Logger

@Path("/")
class ExampleResource {

    private val LOG: Logger = Logger.getLogger(ExampleResource::class.java)

    @POST
    @Path("/validate")
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    fun hello(request: AdmissionReview): AdmissionReview {
        LOG.info(ObjectMapper().writeValueAsString(request))
        request.response = AdmissionResponse().apply {
            allowed = false
            status = with(Status()) {
                message("Try again!")
            }
            uid = request.request!!.uid
        }
        return request
    }
}
